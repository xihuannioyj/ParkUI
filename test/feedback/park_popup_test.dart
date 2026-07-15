import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: child));

/// 用于验证"点击触发后通过 visible 控制弹窗显示"的辅助组件。
class _PopupToggle extends StatefulWidget {
  const _PopupToggle();

  @override
  State<_PopupToggle> createState() => _PopupToggleState();
}

class _PopupToggleState extends State<_PopupToggle> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _visible = true),
          child: const Text('点我弹出'),
        ),
        ParkPopup(
          visible: _visible,
          child: const Text('弹出内容'),
        ),
      ],
    );
  }
}

void main() {
  group('ParkPopup', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkPopup(
        visible: true,
        child: Text('显示弹出层'),
      )));
      expect(find.text('显示弹出层'), findsOneWidget);
    });
    testWidgets('点击显示弹出层', (tester) async {
      await tester.pumpWidget(_wrap(const _PopupToggle()));
      expect(find.text('点我弹出'), findsOneWidget);
      await tester.tap(find.text('点我弹出'));
      await tester.pumpAndSettle();
      expect(find.text('弹出内容'), findsOneWidget);
    });
  });
}
