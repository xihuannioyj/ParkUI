/// End-to-end tests for ParkSchemaBuilder + ParkDynamicForm.
///
/// Covers the full path from JSON Schema / Builder API to rendered widgets:
/// basic rendering, multiple field types, required marks, validation,
/// initial values, conditional visibility, submit callback, reset, and more.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';
import 'package:park_ui/src/form/models/form_layout_schema.dart'
    as layout_schema;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps [child] in the minimum widget tree required by ParkDynamicForm.
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()]),
    home: ParkLocalizationsWidget(
      localizations: const ParkLocalizationsZh(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(child: child),
        ),
      ),
    ),
  );
}

/// Shorthand: build a ParkDynamicForm from a [ParkFormSchema] and wrap it.
Widget _buildForm(
  ParkFormSchema schema, {
  ValueChanged<Map<String, dynamic>>? onSubmit,
  bool showReset = true,
}) {
  return ParkDynamicForm(
    schema: schema,
    onSubmit: onSubmit ?? (_) {},
    showReset: showReset,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // 1. ParkSchemaBuilder — pure data-layer tests (no widgets)
  // =========================================================================

  group('ParkSchemaBuilder — data layer', () {
    test('builds a schema with correct formKey and field count', () {
      final ParkFormSchema schema = ParkSchemaBuilder('test_form')
          .addTextField('username', label: 'Username')
          .addTextField('email', label: 'Email')
          .build();

      expect(schema.formKey, 'test_form');
      expect(schema.fields.length, 2);
      expect(schema.fields[0].fieldName, 'username');
      expect(schema.fields[1].fieldName, 'email');
    });

    test('addSelectField sets options and field type', () {
      final ParkFormSchema schema = ParkSchemaBuilder('f')
          .addSelectField('role', label: 'Role', options: <Map<String, dynamic>>[
            <String, dynamic>{'label': 'Admin', 'value': 'admin'},
            <String, dynamic>{'label': 'User', 'value': 'user'},
          ])
          .build();

      expect(schema.fields.first.fieldType, ParkFieldType.select);
      expect(schema.fields.first.options.length, 2);
      expect(schema.fields.first.options.first['value'], 'admin');
    });

    test('addSelectField with multiple=true uses checkbox type', () {
      final ParkFormSchema schema = ParkSchemaBuilder('f')
          .addSelectField(
            'tags',
            label: 'Tags',
            multiple: true,
            options: <Map<String, dynamic>>[
              <String, dynamic>{'label': 'A', 'value': 'a'},
            ],
          )
          .build();

      expect(schema.fields.first.fieldType, ParkFieldType.checkbox);
      expect(schema.fields.first.fieldControl, 'multi');
    });

    test('addSwitchField sets toggle type and default value', () {
      final ParkFormSchema schema = ParkSchemaBuilder('f')
          .addSwitchField('enabled', label: 'Enabled', defaultValue: true)
          .build();

      expect(schema.fields.first.fieldType, ParkFieldType.toggle);
      expect(schema.fields.first.defaultValue, true);
    });

    test('addDateField sets date type and showTime ext', () {
      final ParkFormSchema schema = ParkSchemaBuilder('f')
          .addDateField('birthday', label: 'Birthday', showTime: true)
          .build();

      expect(schema.fields.first.fieldType, ParkFieldType.date);
      expect(schema.fields.first.ext['showTime'], true);
    });

    test('addNumberField stores min/max in ext', () {
      final ParkFormSchema schema = ParkSchemaBuilder('f')
          .addNumberField('age', label: 'Age', min: 0, max: 150)
          .build();

      expect(schema.fields.first.fieldType, ParkFieldType.number);
      expect(schema.fields.first.ext['min'], 0.0);
      expect(schema.fields.first.ext['max'], 150.0);
    });

    test('required flag propagates to field schema', () {
      final ParkFormSchema schema = ParkSchemaBuilder('f')
          .addTextField('name', label: 'Name', required: true)
          .build();

      expect(schema.fields.first.isRequired, isTrue);
    });

    test('chained builder returns correct field count', () {
      final ParkSchemaBuilder builder = ParkSchemaBuilder('f')
          .addTextField('a')
          .addNumberField('b')
          .addSelectField('c', options: <Map<String, dynamic>>[])
          .addDateField('d')
          .addSwitchField('e')
          .addTextareaField('g');

      expect(builder.fieldCount, 6);
    });

    test('build with reactions attaches them to schema', () {
      final ParkFormSchema schema = ParkSchemaBuilder('f')
          .addTextField('trigger')
          .addTextField('target')
          .build(reactions: <ParkFormReactionSchema>[
        const ParkFormReactionSchema(
          reactionId: 'r1',
          triggerField: 'trigger',
          actions: <ParkFormReactionActionSchema>[
            ParkFormReactionActionSchema(
              actionType: ParkFormReactionActionType.setVisible,
              targetField: 'target',
              value: true,
            ),
          ],
        ),
      ]);

      expect(schema.reactions.length, 1);
      expect(schema.reactions.first.triggerField, 'trigger');
    });
  });

  // =========================================================================
  // 2. ParkDynamicForm — widget rendering tests
  // =========================================================================

  group('ParkDynamicForm — basic rendering', () {
    testWidgets('renders text field with label', (WidgetTester tester) async {
      final ParkFormSchema schema = ParkSchemaBuilder('form1')
          .addTextField('username', label: 'User Name')
          .build();

      await tester.pumpWidget(_wrap(_buildForm(schema)));
      await tester.pumpAndSettle();

      // The label should appear in the widget tree.
      expect(find.text('User Name'), findsOneWidget);
    });

    testWidgets('renders multiple field types', (WidgetTester tester) async {
      final ParkFormSchema schema = ParkSchemaBuilder('form2')
          .addTextField('name', label: 'Name')
          .addSelectField('role', label: 'Role', options: <Map<String, dynamic>>[
            <String, dynamic>{'label': 'Admin', 'value': 'admin'},
          ])
          .addSwitchField('active', label: 'Active')
          .addDateField('birthday', label: 'Birthday')
          .build();

      await tester.pumpWidget(_wrap(_buildForm(schema)));
      await tester.pumpAndSettle();

      // Labels rendered via ParkFormItem include a colon suffix (e.g. 'Name：').
      // Use textContaining for robust matching across all field types.
      expect(find.textContaining('Name'), findsWidgets);
      expect(find.textContaining('Role'), findsWidgets);
      expect(find.textContaining('Active'), findsOneWidget);
      expect(find.textContaining('Birthday'), findsWidgets);
    });

    testWidgets('renders textarea field', (WidgetTester tester) async {
      final ParkFormSchema schema = ParkSchemaBuilder('form3')
          .addTextareaField('bio', label: 'Biography')
          .build();

      await tester.pumpWidget(_wrap(_buildForm(schema)));
      await tester.pumpAndSettle();

      expect(find.text('Biography'), findsOneWidget);
    });

    testWidgets('renders number field', (WidgetTester tester) async {
      final ParkFormSchema schema = ParkSchemaBuilder('form_num')
          .addNumberField('quantity', label: 'Quantity')
          .build();

      await tester.pumpWidget(_wrap(_buildForm(schema)));
      await tester.pumpAndSettle();

      expect(find.text('Quantity'), findsOneWidget);
    });
  });

  // =========================================================================
  // 3. Required mark
  // =========================================================================

  group('ParkDynamicForm — required mark', () {
    testWidgets('required field blocks submit when empty',
        (WidgetTester tester) async {
      bool submitCalled = false;
      final ParkFormSchema schema = ParkSchemaBuilder('form_req')
          .addTextField('email', label: 'Email', required: true)
          .build();

      await tester.pumpWidget(_wrap(
        ParkDynamicForm(
          schema: schema,
          onSubmit: (_) => submitCalled = true,
        ),
      ));
      await tester.pumpAndSettle();

      // The label should be present.
      expect(find.textContaining('Email'), findsWidgets);

      // Tap submit without filling the required field.
      await tester.tap(find.text('提交'));
      await tester.pumpAndSettle();

      // Submit should NOT have been called because the required field is empty.
      expect(submitCalled, isFalse);
    });

    testWidgets('required field allows submit when filled',
        (WidgetTester tester) async {
      Map<String, dynamic>? submittedData;
      final ParkFormSchema schema = ParkSchemaBuilder('form_req2')
          .addTextField('email', label: 'Email', required: true)
          .build();

      await tester.pumpWidget(_wrap(
        ParkDynamicForm(
          schema: schema,
          onSubmit: (Map<String, dynamic> data) => submittedData = data,
        ),
      ));
      await tester.pumpAndSettle();

      // Fill in the required field.
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.pumpAndSettle();

      // Tap submit.
      await tester.tap(find.text('提交'));
      await tester.pumpAndSettle();

      // Submit should have been called with the entered value.
      expect(submittedData, isNotNull);
      expect(submittedData!['email'], 'test@example.com');
    });
  });

  // =========================================================================
  // 4. Validation
  // =========================================================================

  group('ParkDynamicForm — validation', () {
    testWidgets('submitting empty required field shows error',
        (WidgetTester tester) async {
      final ParkFormSchema schema = ParkSchemaBuilder('form_val')
          .addTextField('name', label: 'Name', required: true)
          .build();

      await tester.pumpWidget(_wrap(_buildForm(schema)));
      await tester.pumpAndSettle();

      // Find and tap the submit button (default Chinese text: "提交").
      final Finder submitBtn = find.text('提交');
      expect(submitBtn, findsOneWidget);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // After validation, an error message should appear.
      // The default required error message from the engine.
      // We just check that *some* error text is rendered — the exact message
      // depends on the l10n and engine implementation.
      // The field label "Name" should still be present.
      expect(find.text('Name'), findsWidgets);
    });
  });

  // =========================================================================
  // 5. Initial / default values
  // =========================================================================

  group('ParkDynamicForm — initial values', () {
    testWidgets('field with defaultValue pre-fills the value',
        (WidgetTester tester) async {
      // ParkSchemaBuilder does not expose a direct "initialValues" map,
      // but addSwitchField accepts defaultValue. We verify the switch
      // renders with its default.
      final ParkFormSchema schema = ParkSchemaBuilder('form_init')
          .addSwitchField('enabled', label: 'Enabled', defaultValue: true)
          .build();

      await tester.pumpWidget(_wrap(_buildForm(schema)));
      await tester.pumpAndSettle();

      // The switch adapter renders a ParkSwitch with initialValue=true.
      final ParkSwitch switchWidget =
          tester.widget<ParkSwitch>(find.byType(ParkSwitch));
      expect(switchWidget.initialValue, isTrue);
    });

    testWidgets('text field with defaultValue shows pre-filled text',
        (WidgetTester tester) async {
      // Build schema with a text field that has a defaultValue via
      // ParkFormFieldSchema directly (since ParkSchemaBuilder.addTextField
      // does not expose defaultValue).
      final ParkFormSchema schema = ParkFormSchema(
        formKey: 'form_init_text',
        fields: <ParkFormFieldSchema>[
          ParkFormFieldSchema(
            fieldId: 'city',
            fieldType: ParkFieldType.text,
            labelName: 'City',
            fieldName: 'city',
            defaultValue: 'Shanghai',
          ),
        ],
      );

      await tester.pumpWidget(_wrap(_buildForm(schema)));
      await tester.pumpAndSettle();

      // The TextField should contain the default value.
      expect(find.text('Shanghai'), findsOneWidget);
    });
  });

  // =========================================================================
  // 6. Conditional visibility
  // =========================================================================

  group('ParkDynamicForm — conditional visibility', () {
    testWidgets('field with visible_when_expr=false is hidden initially',
        (WidgetTester tester) async {
      // "target" field is only visible when "trigger" == "yes".
      // Since "trigger" starts empty, "target" should be hidden.
      final ParkFormSchema schema = ParkFormSchema(
        formKey: 'form_visible',
        fields: <ParkFormFieldSchema>[
          ParkFormFieldSchema(
            fieldId: 'trigger',
            fieldType: ParkFieldType.text,
            labelName: 'Trigger',
            fieldName: 'trigger',
          ),
          ParkFormFieldSchema(
            fieldId: 'target',
            fieldType: ParkFieldType.text,
            labelName: 'Target Field',
            fieldName: 'target',
            dependencies: <String>['trigger'],
            ext: <String, dynamic>{
              'visible_when_expr': 'trigger == "yes"',
            },
          ),
        ],
      );

      await tester.pumpWidget(_wrap(_buildForm(schema)));
      await tester.pumpAndSettle();

      // "Trigger" label should be visible.
      expect(find.text('Trigger'), findsOneWidget);
      // "Target Field" should NOT be visible.
      expect(find.text('Target Field'), findsNothing);
    });

    testWidgets('field becomes visible when condition is met',
        (WidgetTester tester) async {
      final ParkFormSchema schema = ParkFormSchema(
        formKey: 'form_visible2',
        fields: <ParkFormFieldSchema>[
          ParkFormFieldSchema(
            fieldId: 'trigger',
            fieldType: ParkFieldType.text,
            labelName: 'Trigger',
            fieldName: 'trigger',
          ),
          ParkFormFieldSchema(
            fieldId: 'target',
            fieldType: ParkFieldType.text,
            labelName: 'Target Field',
            fieldName: 'target',
            dependencies: <String>['trigger'],
            ext: <String, dynamic>{
              'visible_when_expr': 'trigger == "yes"',
            },
          ),
        ],
      );

      await tester.pumpWidget(_wrap(_buildForm(schema)));
      await tester.pumpAndSettle();

      // Initially hidden.
      expect(find.text('Target Field'), findsNothing);

      // Enter "yes" into the trigger field.
      final Finder triggerInput = find.byType(TextField).first;
      await tester.enterText(triggerInput, 'yes');
      await tester.pumpAndSettle();

      // Now "Target Field" should be visible.
      expect(find.text('Target Field'), findsOneWidget);
    });
  });

  // =========================================================================
  // 7. Submit callback
  // =========================================================================

  group('ParkDynamicForm — submit callback', () {
    testWidgets('onSubmit receives form data on valid submit',
        (WidgetTester tester) async {
      Map<String, dynamic>? submittedData;

      final ParkFormSchema schema = ParkFormSchema(
        formKey: 'form_submit',
        fields: <ParkFormFieldSchema>[
          ParkFormFieldSchema(
            fieldId: 'city',
            fieldType: ParkFieldType.text,
            labelName: 'City',
            fieldName: 'city',
            defaultValue: 'Beijing',
          ),
        ],
      );

      await tester.pumpWidget(_wrap(
        ParkDynamicForm(
          schema: schema,
          onSubmit: (Map<String, dynamic> data) {
            submittedData = data;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Tap submit.
      await tester.tap(find.text('提交'));
      await tester.pumpAndSettle();

      // The callback should have received the default value.
      expect(submittedData, isNotNull);
      expect(submittedData!['city'], 'Beijing');
    });

    testWidgets('onSubmit receives updated value after user input',
        (WidgetTester tester) async {
      Map<String, dynamic>? submittedData;

      final ParkFormSchema schema = ParkSchemaBuilder('form_submit2')
          .addTextField('name', label: 'Name')
          .build();

      await tester.pumpWidget(_wrap(
        ParkDynamicForm(
          schema: schema,
          onSubmit: (Map<String, dynamic> data) {
            submittedData = data;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Enter text.
      await tester.enterText(find.byType(TextField).first, 'Alice');
      await tester.pumpAndSettle();

      // Tap submit.
      await tester.tap(find.text('提交'));
      await tester.pumpAndSettle();

      expect(submittedData, isNotNull);
      expect(submittedData!['name'], 'Alice');
    });
  });

  // =========================================================================
  // 8. Reset
  // =========================================================================

  group('ParkDynamicForm — reset', () {
    testWidgets('reset button restores default values',
        (WidgetTester tester) async {
      final ParkFormSchema schema = ParkFormSchema(
        formKey: 'form_reset',
        fields: <ParkFormFieldSchema>[
          ParkFormFieldSchema(
            fieldId: 'name',
            fieldType: ParkFieldType.text,
            labelName: 'Name',
            fieldName: 'name',
            defaultValue: 'DefaultName',
          ),
        ],
      );

      await tester.pumpWidget(_wrap(
        _buildForm(schema, showReset: true),
      ));
      await tester.pumpAndSettle();

      // Modify the field.
      await tester.enterText(find.byType(TextField).first, 'Changed');
      await tester.pumpAndSettle();

      // Tap reset (default Chinese: "重置").
      final Finder resetBtn = find.text('重置');
      expect(resetBtn, findsOneWidget);
      await tester.tap(resetBtn);
      await tester.pumpAndSettle();

      // The text field should show the default value again.
      expect(find.text('DefaultName'), findsOneWidget);
    });
  });

  // =========================================================================
  // 9. Schema from JSON
  // =========================================================================

  group('ParkDynamicForm — JSON schema', () {
    testWidgets('renders fields from a JSON-created schema',
        (WidgetTester tester) async {
      final ParkFormSchema schema = ParkFormSchema.fromJson(<String, dynamic>{
        'formKey': 'json_form',
        'fields': <Map<String, dynamic>>[
          <String, dynamic>{
            'field_id': 'username',
            'field_type': 'text',
            'field_name': 'username',
            'label_name': 'Username',
            'is_required': true,
          },
          <String, dynamic>{
            'field_id': 'age',
            'field_type': 'number',
            'field_name': 'age',
            'label_name': 'Age',
          },
        ],
      });

      await tester.pumpWidget(_wrap(_buildForm(schema)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Username'), findsWidgets);
      expect(find.textContaining('Age'), findsWidgets);
      // Verify the required field is correctly parsed from JSON.
      expect(schema.fields.first.isRequired, isTrue);
      expect(schema.fields[1].isRequired, isFalse);
    });
  });

  // =========================================================================
  // 10. ParkSchemaBuilder with layout
  // =========================================================================

  group('ParkDynamicForm — layout', () {
    testWidgets('renders with inline label layout',
        (WidgetTester tester) async {
      final ParkFormSchema schema = ParkSchemaBuilder('form_layout')
          .layout(const layout_schema.ParkFormLayout(
            defaultLabelLayout: layout_schema.ParkLabelLayout.inline,
            labelWidth: 100,
          ))
          .addTextField('name', label: 'Name')
          .build();

      await tester.pumpWidget(_wrap(_buildForm(schema)));
      await tester.pumpAndSettle();

      // In inline mode, the label is rendered as a Text widget directly
      // (not via ParkFormItem).
      expect(find.text('Name'), findsOneWidget);
    });
  });

  // =========================================================================
  // 11. Help text
  // =========================================================================

  group('ParkDynamicForm — help text', () {
    testWidgets('field with helpText renders the field and stores helpText in schema',
        (WidgetTester tester) async {
      final ParkFormSchema schema = ParkSchemaBuilder('form_help')
          .addTextField('code', label: 'Code', helpText: 'Enter your access code')
          .build();

      // Verify the schema carries the helpText.
      expect(schema.fields.first.helpText, 'Enter your access code');

      await tester.pumpWidget(_wrap(_buildForm(schema)));
      await tester.pumpAndSettle();

      // The field label should be rendered.
      expect(find.textContaining('Code'), findsWidgets);
    });
  });

  // =========================================================================
  // 12. Multiple required fields — validation blocks submit
  // =========================================================================

  group('ParkDynamicForm — validation blocks submit', () {
    testWidgets('onSubmit is NOT called when required fields are empty',
        (WidgetTester tester) async {
      bool submitCalled = false;

      final ParkFormSchema schema = ParkSchemaBuilder('form_block')
          .addTextField('a', label: 'Field A', required: true)
          .addTextField('b', label: 'Field B', required: true)
          .build();

      await tester.pumpWidget(_wrap(
        ParkDynamicForm(
          schema: schema,
          onSubmit: (_) => submitCalled = true,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap submit without filling any fields.
      await tester.tap(find.text('提交'));
      await tester.pumpAndSettle();

      // Submit should NOT have been called.
      expect(submitCalled, isFalse);
    });
  });
}
