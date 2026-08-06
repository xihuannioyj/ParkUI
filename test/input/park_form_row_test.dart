import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/input/park_form_row.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkFormRow', () {
    testWidgets('renders label and child', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkFormRow(
          label: '姓名',
          child: Text('张三'),
        ),
      ));
      expect(find.text('姓名：'), findsOneWidget);
      expect(find.text('张三'), findsOneWidget);
    });

    testWidgets('shows required indicator when required: true', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkFormRow(
          label: '姓名',
          required: true,
          child: Text('张三'),
        ),
      ));
      expect(find.text('*姓名：'), findsOneWidget);
    });

    testWidgets('shows colon by default, hides when showColon: false',
        (tester) async {
      // Default: colon shown
      await tester.pumpWidget(_wrap(
        const ParkFormRow(
          label: '面积',
          child: Text('85'),
        ),
      ));
      expect(find.text('面积：'), findsOneWidget);

      // showColon: false
      await tester.pumpWidget(_wrap(
        const ParkFormRow(
          label: '面积',
          showColon: false,
          child: Text('85'),
        ),
      ));
      expect(find.text('面积'), findsOneWidget);
    });

    testWidgets('shows suffix text', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkFormRow(
          label: '面积',
          suffixText: '㎡',
          child: Text('85.5'),
        ),
      ));
      expect(find.text('㎡'), findsOneWidget);
    });

    testWidgets('shows helper text', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkFormRow(
          label: '备注',
          helperText: '请输入详细信息',
          child: Text(''),
        ),
      ));
      expect(find.text('请输入详细信息'), findsOneWidget);
    });

    testWidgets('readOnly reduces field alpha', (tester) async {
      // Pump readOnly version
      await tester.pumpWidget(_wrap(
        const ParkFormRow(
          label: '状态',
          readOnly: true,
          child: Text('已审核'),
        ),
      ));
      final readOnlyContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      final readOnlyDecoration =
          readOnlyContainer.decoration as BoxDecoration;
      final readOnlyColor = readOnlyDecoration.color!;

      // Pump normal version
      await tester.pumpWidget(_wrap(
        const ParkFormRow(
          label: '状态',
          readOnly: false,
          child: Text('已审核'),
        ),
      ));
      final normalContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      final normalDecoration = normalContainer.decoration as BoxDecoration;
      final normalColor = normalDecoration.color!;

      // readOnly uses lower alpha (0.55) vs normal (0.78)
      expect(readOnlyColor.opacity, lessThan(normalColor.opacity));
    });

    testWidgets('onTap callback fires', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        ParkFormRow(
          label: '选择',
          onTap: () => tapped = true,
          child: const Text('点击选择'),
        ),
      ));
      await tester.tap(find.text('点击选择'));
      expect(tapped, isTrue);
    });

    testWidgets('hides field background when showFieldBackground: false',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkFormRow(
          label: '透明',
          showFieldBackground: false,
          child: Text('无背景'),
        ),
      ));
      // When showFieldBackground is false, no AnimatedContainer for field area
      expect(find.byType(AnimatedContainer), findsNothing);
      expect(find.text('无背景'), findsOneWidget);
    });
  });
}
