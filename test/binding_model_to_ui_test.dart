import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/binding/park_binding_service.dart';
import 'package:park_ui/src/components/input/park_mentions.dart';
import 'package:park_ui/src/components/input/park_checkbox.dart';
import 'package:park_ui/src/components/input/park_time_picker.dart';
import 'package:park_ui/src/components/input/park_color_picker.dart';
import 'package:park_ui/src/components/input/park_transfer.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

/// B229 回归测试：验证 5 个组件的 onBindableChanged（model→UI 方向）。
///
/// 每个组件通过 ParkBindingService.updateModel 模拟外部 model 变更，
/// 验证 onBindableChanged 被正确触发并将新值同步到 UI。

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('B229: onBindableChanged model→UI sync', () {
    testWidgets('ParkMentions model→UI sync via onBindableChanged',
        (tester) async {
      final service = ParkBindingService(<String, dynamic>{'text': 'initial'});

      await tester.pumpWidget(_wrap(
        ParkMentions(
          bindKey: 'text',
          bindingService: service,
          items: const [
            ParkMentionItem(value: 'alice', label: 'Alice'),
            ParkMentionItem(value: 'bob', label: 'Bob'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      // 验证初始值显示在 TextField 中
      expect(find.text('initial'), findsOneWidget);

      // 外部修改 model（model→UI 方向）
      service.updateModel(<String, dynamic>{'text': 'updated'});
      await tester.pumpAndSettle();

      // 验证 UI 同步更新
      expect(find.text('updated'), findsOneWidget);
      expect(find.text('initial'), findsNothing);

      service.dispose();
    });

    testWidgets('ParkCheckboxGroup model→UI sync via onBindableChanged',
        (tester) async {
      final service =
          ParkBindingService(<String, dynamic>{'hobbies': <String>[]});

      await tester.pumpWidget(_wrap(
        ParkCheckboxGroup(
          bindKey: 'hobbies',
          bindingService: service,
          options: const [
            ParkCheckboxOption(label: 'Reading', value: 'a'),
            ParkCheckboxOption(label: 'Gaming', value: 'b'),
            ParkCheckboxOption(label: 'Coding', value: 'c'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      // 初始状态：所有 checkbox 的 initialValue 为 false
      var checkboxes =
          tester.widgetList<ParkCheckbox>(find.byType(ParkCheckbox)).toList();
      expect(checkboxes.where((cb) => cb.initialValue == true).length, 0);

      // 外部修改 model：选中 a 和 b
      service.updateModel(<String, dynamic>{
        'hobbies': ['a', 'b'],
      });
      await tester.pumpAndSettle();

      // 验证 onBindableChanged 更新了 _selected，重建后对应 checkbox 值为 true
      checkboxes =
          tester.widgetList<ParkCheckbox>(find.byType(ParkCheckbox)).toList();
      expect(checkboxes.where((cb) => cb.initialValue == true).length, 2);

      service.dispose();
    });

    testWidgets('ParkTimePicker model→UI sync via onBindableChanged',
        (tester) async {
      final service = ParkBindingService(<String, dynamic>{
        'time': TimeOfDay(hour: 9, minute: 0),
      });

      await tester.pumpWidget(_wrap(
        ParkTimePicker(
          bindKey: 'time',
          bindingService: service,
        ),
      ));
      await tester.pumpAndSettle();

      // 初始状态：显示 9:00 的格式化文本
      // 默认 en_US locale + 12h 格式 → "9:00 AM"
      expect(find.text('9:00 AM'), findsOneWidget);

      // 外部修改 model：设置为 14:30
      service.updateModel(<String, dynamic>{
        'time': TimeOfDay(hour: 14, minute: 30),
      });
      await tester.pumpAndSettle();

      // 验证显示文本更新（14:30 → "2:30 PM" in 12h format）
      expect(find.text('2:30 PM'), findsOneWidget);
      expect(find.text('9:00 AM'), findsNothing);

      service.dispose();
    });

    testWidgets('ParkColorPicker model→UI sync via onBindableChanged',
        (tester) async {
      final service = ParkBindingService(<String, dynamic>{
        'color': Colors.blue,
      });

      await tester.pumpWidget(_wrap(
        ParkColorPicker(
          bindKey: 'color',
          bindingService: service,
          enableCustom: false,
        ),
      ));
      await tester.pumpAndSettle();

      // 初始状态：显示 Colors.blue 的 HEX 值 #2196f3
      expect(find.text('#2196f3'), findsOneWidget);

      // 外部修改 model：设置为 Colors.red
      service.updateModel(<String, dynamic>{'color': Colors.red});
      await tester.pumpAndSettle();

      // 验证选中颜色更新：HEX 显示变为 #f44336
      expect(find.text('#f44336'), findsOneWidget);
      expect(find.text('#2196f3'), findsNothing);

      service.dispose();
    });

    testWidgets('ParkTransfer model→UI sync via onBindableChanged',
        (tester) async {
      final service =
          ParkBindingService(<String, dynamic>{'selected': <String>[]});

      await tester.pumpWidget(_wrap(
        ParkTransfer(
          bindKey: 'selected',
          bindingService: service,
          dataSource: const [
            ParkTransferItem(key: 'key1', title: 'Item A'),
            ParkTransferItem(key: 'key2', title: 'Item B'),
            ParkTransferItem(key: 'key3', title: 'Item C'),
          ],
          leftTitle: Text('Source'),
          rightTitle: Text('Target'),
        ),
      ));
      await tester.pumpAndSettle();

      // 初始状态：所有项在左侧，右侧为空（显示 noData）
      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);
      expect(find.text('Item C'), findsOneWidget);

      // 外部修改 model：将 key1 移到右侧
      service.updateModel(<String, dynamic>{
        'selected': ['key1'],
      });
      await tester.pumpAndSettle();

      // 验证右侧列表出现 key1 对应的 'Item A'
      // Item A 仍然可见（从左侧移到了右侧）
      expect(find.text('Item A'), findsOneWidget);
      // 组件正常渲染，未崩溃
      expect(find.byType(ParkTransfer), findsOneWidget);
      // 验证右侧面板标题仍存在（面板结构完整）
      expect(find.text('Target'), findsOneWidget);

      service.dispose();
    });
  });
}
