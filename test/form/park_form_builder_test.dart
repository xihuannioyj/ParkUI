/// Tests for ParkFormBuilder.
///
/// Covers: fromSchema() creation, field type mapping, required validator
/// auto-injection, default values, async validator registration.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// Helper: build a simple [ParkFormFieldSchema].
ParkFormFieldSchema _field({
  required String name,
  ParkFieldType type = ParkFieldType.text,
  bool required = false,
  int fieldLength = 0,
  int? minLength,
  int? maxLength,
  String? regexExpression,
  String? regexTag,
  dynamic defaultValue,
  String? asyncValidatorKey,
}) {
  return ParkFormFieldSchema(
    fieldId: name,
    fieldType: type,
    labelName: name,
    fieldName: name,
    isRequired: required,
    fieldLength: fieldLength,
    minLength: minLength,
    maxLength: maxLength,
    regexExpression: regexExpression,
    regexTag: regexTag,
    defaultValue: defaultValue,
    asyncValidatorKey: asyncValidatorKey,
  );
}

/// Helper: build a simple [ParkFormSchema].
ParkFormSchema _schema(List<ParkFormFieldSchema> fields) {
  return ParkFormSchema(formKey: 'test_form', fields: fields);
}

void main() {
  group('ParkFormBuilder.fromSchema - basic creation', () {
    test('creates one control per field', () {
      final schema = _schema([
        _field(name: 'username'),
        _field(name: 'email'),
        _field(name: 'age', type: ParkFieldType.number),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      expect(group.controls.length, 3);
      expect(group.controls.containsKey('username'), isTrue);
      expect(group.controls.containsKey('email'), isTrue);
      expect(group.controls.containsKey('age'), isTrue);
      group.dispose();
    });

    test('creates runtime field states for each field', () {
      final schema = _schema([
        _field(name: 'username', required: true),
        _field(name: 'email'),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      expect(group.fields.length, 2);
      expect(group.fields['username']!.fieldKey, 'username');
      expect(group.fields['username']!.required, isTrue);
      expect(group.fields['email']!.required, isFalse);
      group.dispose();
    });

    test('preserves schema reference', () {
      final schema = _schema([_field(name: 'a')]);
      final group = ParkFormBuilder.fromSchema(schema);

      expect(group.schema, same(schema));
      group.dispose();
    });
  });

  group('ParkFormBuilder.fromSchema - default values', () {
    test('uses schema defaultValue when no initialData', () {
      final schema = _schema([
        _field(name: 'status', defaultValue: 'active'),
        _field(name: 'count', type: ParkFieldType.number, defaultValue: 10),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      expect(group.value['status'], 'active');
      expect(group.value['count'], 10);
      group.dispose();
    });

    test('initialData overrides schema defaults', () {
      final schema = _schema([
        _field(name: 'name', defaultValue: 'default'),
        _field(name: 'age', type: ParkFieldType.number, defaultValue: 0),
      ]);
      final group = ParkFormBuilder.fromSchema(
        schema,
        initialData: {'name': 'override', 'age': 25},
      );

      expect(group.value['name'], 'override');
      expect(group.value['age'], 25);
      group.dispose();
    });

    test('partial initialData only overrides specified fields', () {
      final schema = _schema([
        _field(name: 'a', defaultValue: 'da'),
        _field(name: 'b', defaultValue: 'db'),
      ]);
      final group = ParkFormBuilder.fromSchema(
        schema,
        initialData: {'a': 'override'},
      );

      expect(group.value['a'], 'override');
      expect(group.value['b'], 'db');
      group.dispose();
    });
  });

  group('ParkFormBuilder.fromSchema - field type mapping', () {
    test('various field types create correct controls', () {
      final schema = _schema([
        _field(name: 'text', type: ParkFieldType.text),
        _field(name: 'num', type: ParkFieldType.number),
        _field(name: 'sel', type: ParkFieldType.select),
        _field(name: 'chk', type: ParkFieldType.checkbox),
        _field(name: 'dt', type: ParkFieldType.date),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      expect(group.controls.length, 5);
      // All controls should be ParkFormControl instances
      for (final control in group.controls.values) {
        expect(control, isA<ParkFormControl>());
      }
      group.dispose();
    });

    test('field runtime state reflects schema fieldType', () {
      final schema = _schema([
        _field(name: 'text', type: ParkFieldType.text),
        _field(name: 'sel', type: ParkFieldType.select),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      expect(group.fields['text']!.fieldType, 'text');
      expect(group.fields['sel']!.fieldType, 'select');
      group.dispose();
    });
  });

  group('ParkFormBuilder.fromSchema - required field auto-validation', () {
    test('required field gets required validator', () async {
      final schema = _schema([
        _field(name: 'username', required: true),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      // Empty value should fail validation
      final result = await group.validate();
      expect(result, isFalse);
      expect(group.errors.containsKey('username'), isTrue);
      expect(group.errors['username']!.first.key, 'required');
      group.dispose();
    });

    test('required field passes when value is non-empty', () async {
      final schema = _schema([
        _field(name: 'username', required: true),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);
      group.patchValue({'username': 'alice'});

      final result = await group.validate();
      expect(result, isTrue);
      group.dispose();
    });

    test('non-required field passes with empty value', () async {
      final schema = _schema([
        _field(name: 'optional'),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      final result = await group.validate();
      expect(result, isTrue);
      group.dispose();
    });
  });

  group('ParkFormBuilder.fromSchema - length validators', () {
    test('maxLength validator from fieldLength', () async {
      final schema = _schema([
        _field(name: 'code', fieldLength: 3),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);
      group.patchValue({'code': 'abcdef'});

      final result = await group.validate();
      expect(result, isFalse);
      expect(group.errors['code']!.first.key, 'maxLength');
      group.dispose();
    });

    test('maxLength validator from maxLength property', () async {
      final schema = _schema([
        _field(name: 'code', maxLength: 3),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);
      group.patchValue({'code': 'abcdef'});

      final result = await group.validate();
      expect(result, isFalse);
      expect(group.errors['code']!.first.key, 'maxLength');
      group.dispose();
    });

    test('minLength validator', () async {
      final schema = _schema([
        _field(name: 'code', minLength: 5),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);
      group.patchValue({'code': 'ab'});

      final result = await group.validate();
      expect(result, isFalse);
      expect(group.errors['code']!.first.key, 'minLength');
      group.dispose();
    });
  });

  group('ParkFormBuilder.fromSchema - regex validators', () {
    test('regexExpression validator', () async {
      final schema = _schema([
        _field(name: 'email', regexExpression: r'^[\w]+@[\w]+\.\w+$'),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);
      group.patchValue({'email': 'not-an-email'});

      final result = await group.validate();
      expect(result, isFalse);
      expect(group.errors['email']!.first.key, 'pattern');
      group.dispose();
    });

    test('regexExpression passes with valid value', () async {
      final schema = _schema([
        _field(name: 'email', regexExpression: r'^[\w]+@[\w]+\.\w+$'),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);
      group.patchValue({'email': 'test@example.com'});

      final result = await group.validate();
      expect(result, isTrue);
      group.dispose();
    });
  });

  group('ParkFormBuilder - async validator registration', () {
    test('registered async validator is picked up by fromSchema', () async {
      // Register a global async validator
      ParkFormBuilder.registerAsyncValidator(
        'unique_check',
        (dynamic value) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          if (value == 'taken') {
            return ParkFormError('unique', 'Already taken');
          }
          return null;
        },
      );

      final schema = _schema([
        _field(name: 'username', asyncValidatorKey: 'unique_check'),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      group.patchValue({'username': 'taken'});
      final result = await group.validate();
      expect(result, isFalse);
      expect(group.errors['username']!.first.key, 'unique');

      group.patchValue({'username': 'available'});
      final result2 = await group.validate();
      expect(result2, isTrue);
      group.dispose();
    });

    test('unregistered asyncValidatorKey results in no async validators', () async {
      final schema = _schema([
        _field(name: 'field', asyncValidatorKey: 'nonexistent_key'),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      // Should pass validation since no async validator is registered
      final result = await group.validate();
      expect(result, isTrue);
      group.dispose();
    });
  });

  group('ParkFormBuilder.fromSchema - field runtime states', () {
    test('field hidden/readonly from schema', () {
      final schema = _schema([
        ParkFormFieldSchema(
          fieldId: 'hidden_field',
          fieldType: ParkFieldType.text,
          labelName: 'Hidden',
          fieldName: 'hidden_field',
          hidden: true,
        ),
        ParkFormFieldSchema(
          fieldId: 'readonly_field',
          fieldType: ParkFieldType.text,
          labelName: 'ReadOnly',
          fieldName: 'readonly_field',
          isReadonly: true,
        ),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      expect(group.fields['hidden_field']!.hidden, isTrue);
      expect(group.fields['readonly_field']!.readonly, isTrue);
      group.dispose();
    });

    test('field options from schema', () {
      final schema = _schema([
        ParkFormFieldSchema(
          fieldId: 'color',
          fieldType: ParkFieldType.select,
          labelName: 'Color',
          fieldName: 'color',
          options: [
            {'label': 'Red', 'value': 'red'},
            {'label': 'Blue', 'value': 'blue'},
          ],
        ),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      expect(group.fields['color']!.options, isNotNull);
      expect(group.fields['color']!.options!.length, 2);
      group.dispose();
    });
  });
}
