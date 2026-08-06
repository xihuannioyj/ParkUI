import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget buildVisibilityGuardApp(Widget child) {
  final ParkThemeData theme = ParkThemeData.light();
  return MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[theme]),
    home: Scaffold(body: child),
  );
}

ParkFormSchema buildVisibilitySchema() {
  return const ParkFormSchema(
    formKey: 'visibility_guard',
    fields: <ParkFormFieldSchema>[
      ParkFormFieldSchema(
        fieldId: 'f_switch',
        fieldName: 'toggle',
        labelName: '开关',
        fieldType: ParkFieldType.toggle,
      ),
      ParkFormFieldSchema(
        fieldId: 'f_extra',
        fieldName: 'extra',
        labelName: '附加字段',
        fieldType: ParkFieldType.text,
        fieldPrompt: '请输入附加内容',
        ext: <String, dynamic>{'visible_when_expr': 'toggle == true'},
        dependencies: <String>['toggle'],
      ),
    ],
  );
}

void main() {
  testWidgets('依赖可见字段在切换后显示与隐藏正常', (WidgetTester tester) async {
    final ParkFormSchema schema = buildVisibilitySchema();

    await tester.pumpWidget(
      buildVisibilityGuardApp(
        ParkDynamicForm(schema: schema, onSubmit: (_) {}),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('附加字段'), findsNothing);

    await tester.tap(find.byType(ParkSwitch));
    await tester.pumpAndSettle();

    expect(find.text('附加字段'), findsOneWidget);

    await tester.tap(find.byType(ParkSwitch));
    await tester.pumpAndSettle();

    expect(find.text('附加字段'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('显隐切换时无关兄弟字段输入值不会丢失', (WidgetTester tester) async {
    const ParkFormSchema schema = ParkFormSchema(
      formKey: 'visibility_guard_with_sibling',
      fields: <ParkFormFieldSchema>[
        ParkFormFieldSchema(
          fieldId: 'f_switch',
          fieldName: 'toggle',
          labelName: '开关',
          fieldType: ParkFieldType.toggle,
        ),
        ParkFormFieldSchema(
          fieldId: 'f_note',
          fieldName: 'note',
          labelName: '备注',
          fieldType: ParkFieldType.text,
          fieldPrompt: '请输入备注',
        ),
        ParkFormFieldSchema(
          fieldId: 'f_extra',
          fieldName: 'extra',
          labelName: '附加字段',
          fieldType: ParkFieldType.text,
          fieldPrompt: '请输入附加内容',
          ext: <String, dynamic>{'visible_when_expr': 'toggle == true'},
          dependencies: <String>['toggle'],
        ),
      ],
    );

    await tester.pumpWidget(
      buildVisibilityGuardApp(
        ParkDynamicForm(schema: schema, onSubmit: (_) {}),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '稳定备注');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ParkSwitch));
    await tester.pumpAndSettle();

    expect(find.text('附加字段'), findsOneWidget);
    expect(find.text('稳定备注'), findsOneWidget);

    await tester.tap(find.byType(ParkSwitch));
    await tester.pumpAndSettle();

    expect(find.text('附加字段'), findsNothing);
    expect(find.text('稳定备注'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('提交后错误态只局部清理，不误伤其他字段', (WidgetTester tester) async {
    const ParkFormSchema schema = ParkFormSchema(
      formKey: 'error_scope_guard',
      fields: <ParkFormFieldSchema>[
        ParkFormFieldSchema(
          fieldId: 'f_a',
          fieldName: 'fieldA',
          labelName: '字段A',
          fieldType: ParkFieldType.text,
          fieldPrompt: '请输入字段A',
          isRequired: true,
        ),
        ParkFormFieldSchema(
          fieldId: 'f_b',
          fieldName: 'fieldB',
          labelName: '字段B',
          fieldType: ParkFieldType.text,
          fieldPrompt: '请输入字段B',
          isRequired: true,
        ),
      ],
    );

    await tester.pumpWidget(
      buildVisibilityGuardApp(
        ParkDynamicForm(schema: schema, onSubmit: (_) {}),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('提交'));
    await tester.pumpAndSettle();

    expect(find.textContaining('字段A'), findsWidgets);
    expect(find.textContaining('字段B'), findsWidgets);

    await tester.enterText(find.byType(TextField).at(0), '已填写A');
    await tester.pumpAndSettle();

    await tester.tap(find.text('提交'));
    await tester.pumpAndSettle();

    expect(find.text('已填写A'), findsOneWidget);
    expect(find.text('字段B'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
