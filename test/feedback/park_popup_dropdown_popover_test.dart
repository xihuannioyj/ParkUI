import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

void main() {
  group('ParkPopup', () {
    testWidgets('点击遮罩应只触发一次关闭回调并隐藏内容', (WidgetTester tester) async {
      int dismissCount = 0;

      await tester.pumpWidget(
        _TestApp(child: _PopupHarness(onDismiss: () => dismissCount++)),
      );

      expect(find.text('popup-content'), findsOneWidget);

      await tester.tapAt(const Offset(8, 8));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 320));

      expect(dismissCount, 1);
      expect(find.text('popup-content'), findsNothing);
    });

    testWidgets('禁用遮罩关闭后点击外部不应关闭弹层', (WidgetTester tester) async {
      int dismissCount = 0;

      await tester.pumpWidget(
        _TestApp(
          child: _PopupHarness(
            dismissOnBarrierTap: false,
            onDismiss: () => dismissCount++,
          ),
        ),
      );

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      expect(dismissCount, 0);
      expect(find.text('popup-content'), findsOneWidget);
    });
  });

  group('ParkDropdownMenu', () {
    testWidgets('closeOnTapOutside=false 时点击外部不应关闭菜单', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestApp(child: _DropdownHarness(closeOnTapOutside: false)),
      );

      await tester.tap(find.text('打开菜单'));
      await tester.pumpAndSettle();
      expect(find.text('菜单项 A'), findsOneWidget);

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      expect(find.text('菜单项 A'), findsOneWidget);
    });

    testWidgets('closeOnSelect=false 时选中后菜单保持打开', (WidgetTester tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        _TestApp(
          child: _DropdownHarness(
            closeOnSelect: false,
            onSelected: (item) => selectedValue = item.value,
          ),
        ),
      );

      await tester.tap(find.text('打开菜单'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('菜单项 A'));
      await tester.pumpAndSettle();

      expect(selectedValue, 'a');
      expect(find.text('菜单项 A'), findsOneWidget);
      expect(find.text('菜单项 B'), findsOneWidget);
    });

    testWidgets('打开状态下更新 items 应保持菜单内容一致', (WidgetTester tester) async {
      final ValueNotifier<List<ParkDropdownItem>> itemsNotifier =
          ValueNotifier<List<ParkDropdownItem>>(const <ParkDropdownItem>[
            ParkDropdownItem(label: '菜单项 A', value: 'a'),
          ]);

      await tester.pumpWidget(
        _TestApp(
          child: ValueListenableBuilder<List<ParkDropdownItem>>(
            valueListenable: itemsNotifier,
            builder: (BuildContext context, List<ParkDropdownItem> items, _) {
              return Center(
                child: ParkDropdownMenu(
                  items: items,
                  trigger: const Text('打开菜单'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('打开菜单'));
      await tester.pumpAndSettle();
      expect(find.text('菜单项 A'), findsOneWidget);
      expect(find.text('菜单项 B'), findsNothing);

      itemsNotifier.value = const <ParkDropdownItem>[
        ParkDropdownItem(label: '菜单项 B', value: 'b'),
      ];
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('菜单项 A'), findsNothing);
      expect(find.text('菜单项 B'), findsOneWidget);
    });
  });

  group('ParkPopover', () {
    testWidgets('默认点击外部应关闭气泡', (WidgetTester tester) async {
      await tester.pumpWidget(const _TestApp(child: _PopoverHarness()));

      await tester.tap(find.text('打开气泡'));
      await tester.pumpAndSettle();
      expect(find.text('popover-content'), findsOneWidget);

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      expect(find.text('popover-content'), findsNothing);
    });

    testWidgets('closeOnTapOutside=false 时点击外部不应关闭气泡', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestApp(child: _PopoverHarness(closeOnTapOutside: false)),
      );

      await tester.tap(find.text('打开气泡'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      expect(find.text('popover-content'), findsOneWidget);
    });

    testWidgets('打开状态下更新 content 应保持展示内容一致', (WidgetTester tester) async {
      final ValueNotifier<String> contentNotifier = ValueNotifier<String>(
        '旧内容',
      );

      await tester.pumpWidget(
        _TestApp(
          child: ValueListenableBuilder<String>(
            valueListenable: contentNotifier,
            builder: (BuildContext context, String content, _) {
              return Center(
                child: ParkPopover(
                  trigger: const Text('打开气泡'),
                  content: Text(content),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('打开气泡'));
      await tester.pumpAndSettle();
      expect(find.text('旧内容'), findsOneWidget);

      contentNotifier.value = '新内容';
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('旧内容'), findsNothing);
      expect(find.text('新内容'), findsOneWidget);
    });
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
      ),
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            const Positioned.fill(child: ColoredBox(color: Colors.white)),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}

class _PopupHarness extends StatefulWidget {
  const _PopupHarness({this.dismissOnBarrierTap = true, this.onDismiss});

  final bool dismissOnBarrierTap;
  final VoidCallback? onDismiss;

  @override
  State<_PopupHarness> createState() => _PopupHarnessState();
}

class _PopupHarnessState extends State<_PopupHarness> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ParkPopup(
          visible: _visible,
          dismissOnBarrierTap: widget.dismissOnBarrierTap,
          onDismiss: () {
            widget.onDismiss?.call();
            if (_visible) {
              setState(() => _visible = false);
            }
          },
          child: Container(
            width: 120,
            height: 80,
            color: Colors.blue,
            alignment: Alignment.center,
            child: const Text('popup-content'),
          ),
        ),
      ],
    );
  }
}

class _DropdownHarness extends StatelessWidget {
  const _DropdownHarness({
    this.closeOnTapOutside = true,
    this.closeOnSelect = true,
    this.onSelected,
  });

  final bool closeOnTapOutside;
  final bool closeOnSelect;
  final ValueChanged<ParkDropdownItem>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ParkDropdownMenu(
        closeOnTapOutside: closeOnTapOutside,
        closeOnSelect: closeOnSelect,
        items: const <ParkDropdownItem>[
          ParkDropdownItem(label: '菜单项 A', value: 'a'),
          ParkDropdownItem(label: '菜单项 B', value: 'b'),
        ],
        onSelected: onSelected,
        trigger: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.blue,
          child: const Text('打开菜单'),
        ),
      ),
    );
  }
}

class _PopoverHarness extends StatelessWidget {
  const _PopoverHarness({this.closeOnTapOutside = true});

  final bool closeOnTapOutside;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ParkPopover(
        closeOnTapOutside: closeOnTapOutside,
        trigger: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.blue,
          child: const Text('打开气泡'),
        ),
        content: const Text('popover-content'),
      ),
    );
  }
}
