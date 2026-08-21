import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkForm', () {
    // -----------------------------------------------------------------------
    // Basic rendering
    // -----------------------------------------------------------------------

    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(children: [])));
      expect(find.byType(ParkForm), findsOneWidget);
    });

    testWidgets('包含sections', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(children: [
        ParkFormSection(
            title: '分组1',
            children: [ParkFormItem(label: '字段', child: Text('值'))]),
      ])));
      expect(find.text('分组1'), findsOneWidget);
    });

    testWidgets('renders children widgets', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(
        children: [
          ParkFormItem(label: '姓名', child: Text('张三')),
          ParkFormItem(label: '年龄', child: Text('25')),
        ],
      )));
      expect(find.text('张三'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // showDefaultActions
    // -----------------------------------------------------------------------

    testWidgets('showDefaultActions true shows submit button', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(
        showDefaultActions: true,
        children: [],
      )));
      // Default submit button text from localization
      expect(find.byType(ParkForm), findsOneWidget);
      // The form should render a submit button (text varies by locale)
      expect(find.text('提交'), findsOneWidget);
    });

    testWidgets('showDefaultActions false hides buttons', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(
        showDefaultActions: false,
        children: [],
      )));
      // Submit button should not be present
      expect(find.text('提交'), findsNothing);
    });

    testWidgets('custom footer replaces default buttons', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(
        showDefaultActions: true,
        footer: Text('Custom Footer'),
        children: [],
      )));
      expect(find.text('Custom Footer'), findsOneWidget);
      expect(find.text('提交'), findsNothing);
    });

    testWidgets('showReset true shows reset button', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(
        showDefaultActions: true,
        showReset: true,
        children: [],
      )));
      expect(find.text('重置'), findsOneWidget);
      expect(find.text('提交'), findsOneWidget);
    });

    testWidgets('showReset false hides reset button', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(
        showDefaultActions: true,
        showReset: false,
        children: [],
      )));
      expect(find.text('重置'), findsNothing);
      expect(find.text('提交'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // Submit callback
    // -----------------------------------------------------------------------

    testWidgets('onSubmit is called when submit button is tapped',
        (tester) async {
      Map<String, dynamic>? submittedValues;

      await tester.pumpWidget(_wrap(ParkForm(
        onSubmit: (values) {
          submittedValues = values;
        },
        children: const [],
      )));

      // Tap the submit button
      await tester.tap(find.text('提交'));
      await tester.pump();

      expect(submittedValues, isNotNull);
    });

    testWidgets('custom submitLabel is used', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(
        submitLabel: 'Save',
        showDefaultActions: true,
        children: [],
      )));
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('提交'), findsNothing);
    });

    testWidgets('custom resetLabel is used', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(
        resetLabel: 'Clear',
        showDefaultActions: true,
        showReset: true,
        children: [],
      )));
      expect(find.text('Clear'), findsOneWidget);
      expect(find.text('重置'), findsNothing);
    });

    // -----------------------------------------------------------------------
    // Validation
    // -----------------------------------------------------------------------

    testWidgets('form does not submit when validation fails', (tester) async {
      bool submitCalled = false;
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(_wrap(ParkForm(
        formKey: formKey,
        onSubmit: (values) {
          submitCalled = true;
        },
        children: [
          ParkFormItem(
            label: 'Required Field',
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
              onSaved: (value) {},
            ),
          ),
        ],
      )));

      // Tap submit without filling the required field
      await tester.tap(find.text('提交'));
      await tester.pump();

      // Submit should not have been called since validation failed
      expect(submitCalled, isFalse);
      // Error message should be visible
      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('form submits when validation passes', (tester) async {
      Map<String, dynamic>? submittedValues;
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(_wrap(ParkForm(
        formKey: formKey,
        onSubmit: (values) {
          submittedValues = values;
        },
        children: [
          ParkFormItem(
            label: 'Name',
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
              onSaved: (value) {},
            ),
          ),
        ],
      )));

      // Enter a value
      await tester.enterText(find.byType(TextFormField), 'John');
      await tester.pump();

      // Tap submit
      await tester.tap(find.text('提交'));
      await tester.pump();

      expect(submittedValues, isNotNull);
    });

    // -----------------------------------------------------------------------
    // initialValues
    // -----------------------------------------------------------------------

    testWidgets('initialValues populates form values', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(_wrap(ParkForm(
        formKey: formKey,
        initialValues: const {
          'name': 'Alice',
          'age': 30,
        },
        onSubmit: (_) {},
        children: const [],
      )));

      // Access the form state to verify values
      final formState =
          tester.state<ParkFormState>(find.byType(ParkForm));
      expect(formState.values['name'], equals('Alice'));
      expect(formState.values['age'], equals(30));
    });

    // -----------------------------------------------------------------------
    // onValuesChange callback
    // -----------------------------------------------------------------------

    testWidgets('onValuesChange fires when setValue is called',
        (tester) async {
      Map<String, dynamic>? changedValues;
      Map<String, dynamic>? allValues;

      await tester.pumpWidget(_wrap(ParkForm(
        onValuesChange: (changed, all) {
          changedValues = changed;
          allValues = all;
        },
        onSubmit: (_) {},
        children: const [],
      )));

      // Access form state and call setValue
      final formState =
          tester.state<ParkFormState>(find.byType(ParkForm));
      formState.setValue('username', 'testuser');

      expect(changedValues, isNotNull);
      expect(changedValues!['username'], equals('testuser'));
      expect(allValues!['username'], equals('testuser'));
    });

    testWidgets('onValuesChange provides all current values', (tester) async {
      Map<String, dynamic>? allValues;

      await tester.pumpWidget(_wrap(ParkForm(
        initialValues: const {'existing': 'value'},
        onValuesChange: (changed, all) {
          allValues = all;
        },
        onSubmit: (_) {},
        children: const [],
      )));

      final formState =
          tester.state<ParkFormState>(find.byType(ParkForm));
      formState.setValue('newField', 'newValue');

      expect(allValues, isNotNull);
      expect(allValues!['existing'], equals('value'));
      expect(allValues!['newField'], equals('newValue'));
    });

    // -----------------------------------------------------------------------
    // Reset functionality
    // -----------------------------------------------------------------------

    testWidgets('reset restores initial values', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(_wrap(ParkForm(
        formKey: formKey,
        initialValues: const {'name': 'Alice'},
        onReset: () {},
        onSubmit: (_) {},
        children: const [],
      )));

      final formState =
          tester.state<ParkFormState>(find.byType(ParkForm));
      expect(formState.values['name'], equals('Alice'));

      // 修改值后再 reset：应恢复到 initialValues（而非清空，
      // 否则 reset 后 submit 会丢失所有初始字段）
      formState.setValue('name', 'Bob');
      formState.reset();
      await tester.pump();

      expect(formState.values['name'], equals('Alice'),
          reason: 'reset 应恢复 initialValues（P1 修复）');
    });

    testWidgets('onReset callback is invoked', (tester) async {
      bool resetCalled = false;

      await tester.pumpWidget(_wrap(ParkForm(
        showDefaultActions: true,
        showReset: true,
        onReset: () {
          resetCalled = true;
        },
        onSubmit: (_) {},
        children: const [],
      )));

      // Tap the reset button
      await tester.tap(find.text('重置'));
      await tester.pump();

      expect(resetCalled, isTrue);
    });

    // -----------------------------------------------------------------------
    // Form state access
    // -----------------------------------------------------------------------

    testWidgets('ParkFormState.values returns current values', (tester) async {
      await tester.pumpWidget(_wrap(ParkForm(
        initialValues: const {
          'field1': 'value1',
          'field2': 42,
        },
        onSubmit: (_) {},
        children: const [],
      )));

      final formState =
          tester.state<ParkFormState>(find.byType(ParkForm));
      expect(formState.values['field1'], equals('value1'));
      expect(formState.values['field2'], equals(42));
    });

    testWidgets('ParkFormState.setValue updates values', (tester) async {
      await tester.pumpWidget(_wrap(ParkForm(
        onSubmit: (_) {},
        children: const [],
      )));

      final formState =
          tester.state<ParkFormState>(find.byType(ParkForm));
      formState.setValue('key', 'value');
      expect(formState.values['key'], equals('value'));
    });

    testWidgets('ParkFormState.removeValue removes a value', (tester) async {
      await tester.pumpWidget(_wrap(ParkForm(
        initialValues: const {'toRemove': 'data'},
        onSubmit: (_) {},
        children: const [],
      )));

      final formState =
          tester.state<ParkFormState>(find.byType(ParkForm));
      expect(formState.values.containsKey('toRemove'), isTrue);

      formState.removeValue('toRemove');
      expect(formState.values.containsKey('toRemove'), isFalse);
    });

    // -----------------------------------------------------------------------
    // Loading and submitting states
    // -----------------------------------------------------------------------

    testWidgets('loading state shows loading indicator', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(
        loading: true,
        showDefaultActions: true,
        children: [],
      )));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('submitting state shows loading in submit button',
        (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(
        submitting: true,
        showDefaultActions: true,
        children: [],
      )));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('submit does nothing when submitting is true', (tester) async {
      bool submitCalled = false;

      await tester.pumpWidget(_wrap(ParkForm(
        submitting: true,
        onSubmit: (values) {
          submitCalled = true;
        },
        children: const [],
      )));

      final formState =
          tester.state<ParkFormState>(find.byType(ParkForm));
      final result = formState.submit();

      expect(result, isFalse);
      expect(submitCalled, isFalse);
    });

    testWidgets('submit does nothing when loading is true', (tester) async {
      bool submitCalled = false;

      await tester.pumpWidget(_wrap(ParkForm(
        loading: true,
        onSubmit: (values) {
          submitCalled = true;
        },
        children: const [],
      )));

      final formState =
          tester.state<ParkFormState>(find.byType(ParkForm));
      final result = formState.submit();

      expect(result, isFalse);
      expect(submitCalled, isFalse);
    });

    // -----------------------------------------------------------------------
    // Form layout
    // -----------------------------------------------------------------------

    testWidgets('vertical layout renders correctly', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(
        layout: ParkFormLayout.vertical,
        colon: false,
        children: [
          ParkFormItem(label: 'Field', child: Text('Value')),
        ],
      )));
      expect(find.text('Field'), findsOneWidget);
      expect(find.text('Value'), findsOneWidget);
    });

    testWidgets('horizontal layout renders correctly', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(
        layout: ParkFormLayout.horizontal,
        labelWidth: 120,
        colon: false,
        children: [
          ParkFormItem(label: 'Field', child: Text('Value')),
        ],
      )));
      expect(find.text('Field'), findsOneWidget);
      expect(find.text('Value'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // Required mark
    // -----------------------------------------------------------------------

    testWidgets('requiredMark asterisk shows asterisk', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(
        requiredMark: ParkRequiredMark.asterisk,
        children: [
          ParkFormItem(label: 'Required', required: true, child: Text('Value')),
        ],
      )));
      expect(find.text('*'), findsOneWidget);
    });

    testWidgets('requiredMark none hides asterisk', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(
        requiredMark: ParkRequiredMark.none,
        children: [
          ParkFormItem(label: 'Optional', child: Text('Value')),
        ],
      )));
      expect(find.text('*'), findsNothing);
    });

    // -----------------------------------------------------------------------
    // Watch / Unwatch field changes
    // -----------------------------------------------------------------------

    testWidgets('watch notifies on field value change', (tester) async {
      dynamic watchedValue;

      await tester.pumpWidget(_wrap(ParkForm(
        onSubmit: (_) {},
        children: const [],
      )));

      final formState =
          tester.state<ParkFormState>(find.byType(ParkForm));

      formState.watch('myField', (value) {
        watchedValue = value;
      });

      formState.setValue('myField', 'newValue');
      expect(watchedValue, equals('newValue'));
    });

    testWidgets('unwatch stops notifications', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(_wrap(ParkForm(
        onSubmit: (_) {},
        children: const [],
      )));

      final formState =
          tester.state<ParkFormState>(find.byType(ParkForm));

      formState.watch('myField', (value) {
        callCount++;
      });

      formState.setValue('myField', 'first');
      expect(callCount, equals(1));

      formState.unwatch('myField');
      formState.setValue('myField', 'second');
      expect(callCount, equals(1)); // Should not increment after unwatch
    });

    // -----------------------------------------------------------------------
    // External formKey
    // -----------------------------------------------------------------------

    testWidgets('external formKey can validate form', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(_wrap(ParkForm(
        formKey: formKey,
        onSubmit: (_) {},
        showDefaultActions: false,
        children: [
          ParkFormItem(
            label: 'Name',
            name: 'name',
            rules: const [ParkFormRule(required: true, message: 'Required')],
            child: const Text(''),
          ),
        ],
      )));

      // Validate using external formKey — the ParkFormItem's FormField
      // runs rules-based validation and displays the error.
      final isValid = formKey.currentState?.validate() ?? false;
      expect(isValid, isFalse);
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
    });
  });
}
