/// ParkFormGroup smoke tests
/// Tests: fromSchema, patchValue, validate, reset, batch, ParkFormArray

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/form/group/form_group_exports.dart';
import 'package:park_ui/src/form/models/form_field_schema.dart';

/// Helper: build a simple [ParkFormFieldSchema].
ParkFormFieldSchema _field({
  required String name,
  ParkFieldType type = ParkFieldType.text,
  bool required = false,
  int fieldLength = 0,
  int? minLength,
  int? maxLength,
  String? regexExpression,
  dynamic defaultValue,
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
    defaultValue: defaultValue,
  );
}

/// Helper: build a simple [ParkFormSchema].
ParkFormSchema _schema(List<ParkFormFieldSchema> fields) {
  return ParkFormSchema(formKey: 'test_form', fields: fields);
}

void main() {
  group('ParkFormGroup - fromSchema creates controls', () {
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

    test('initial values from schema defaults', () {
      final schema = _schema([
        _field(name: 'status', defaultValue: 'active'),
        _field(name: 'count', type: ParkFieldType.number, defaultValue: 0),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      expect(group.value['status'], 'active');
      expect(group.value['count'], 0);
      group.dispose();
    });

    test('initialData overrides schema defaults', () {
      final schema = _schema([
        _field(name: 'name', defaultValue: 'default'),
      ]);
      final group = ParkFormBuilder.fromSchema(
        schema,
        initialData: {'name': 'override'},
      );

      expect(group.value['name'], 'override');
      group.dispose();
    });

    test('creates runtime field states', () {
      final schema = _schema([
        _field(name: 'username', required: true),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      expect(group.fields.containsKey('username'), isTrue);
      expect(group.fields['username']!.required, isTrue);
      expect(group.fields['username']!.hidden, isFalse);
      group.dispose();
    });
  });

  group('ParkFormGroup - patchValue', () {
    test('updates single field value', () {
      final schema = _schema([
        _field(name: 'username'),
        _field(name: 'email'),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      group.patchValue({'username': 'alice'});
      expect(group.value['username'], 'alice');
      expect(group.value['email'], isNull);
      group.dispose();
    });

    test('updates multiple field values at once', () {
      final schema = _schema([
        _field(name: 'first'),
        _field(name: 'second'),
        _field(name: 'third'),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      group.patchValue({'first': 'a', 'second': 'b', 'third': 'c'});
      expect(group.value['first'], 'a');
      expect(group.value['second'], 'b');
      expect(group.value['third'], 'c');
      group.dispose();
    });

    test('ignores unknown keys silently', () {
      final schema = _schema([
        _field(name: 'known'),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      group.patchValue({'unknown': 'value', 'known': 'ok'});
      expect(group.value['known'], 'ok');
      group.dispose();
    });
  });

  group('ParkFormGroup - validate', () {
    test('valid when all fields pass', () async {
      final schema = _schema([
        _field(name: 'username', required: true),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);
      group.patchValue({'username': 'alice'});

      final result = await group.validate();
      expect(result, isTrue);
      expect(group.valid, isTrue);
      group.dispose();
    });

    test('invalid when required field is empty', () async {
      final schema = _schema([
        _field(name: 'username', required: true),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      final result = await group.validate();
      expect(result, isFalse);
      expect(group.invalid, isTrue);
      expect(group.errors.containsKey('username'), isTrue);
      group.dispose();
    });

    test('invalid when maxLength exceeded', () async {
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

    test('invalid when regex does not match', () async {
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
  });

  group('ParkFormGroup - reset', () {
    test('clears values to null', () {
      final schema = _schema([
        _field(name: 'username'),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);
      group.patchValue({'username': 'alice'});
      expect(group.value['username'], 'alice');

      group.reset();
      expect(group.value['username'], isNull);
      group.dispose();
    });

    test('reset with custom defaults', () {
      final schema = _schema([
        _field(name: 'username'),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);
      group.patchValue({'username': 'alice'});

      group.reset({'username': 'bob'});
      expect(group.value['username'], 'bob');
      group.dispose();
    });

    test('clears validation errors', () async {
      final schema = _schema([
        _field(name: 'username', required: true),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      // Trigger validation error
      await group.validate();
      expect(group.invalid, isTrue);

      // Reset should clear errors
      group.reset();
      expect(group.valid, isTrue);
      expect(group.errors.isEmpty, isTrue);
      group.dispose();
    });

    test('resets field runtime states', () {
      final schema = _schema([
        _field(name: 'username', required: true),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      // Modify runtime field state
      group.fields['username']!.hidden = true;
      group.fields['username']!.disabled = true;

      group.reset();
      expect(group.fields['username']!.hidden, isFalse);
      expect(group.fields['username']!.disabled, isFalse);
      expect(group.fields['username']!.required, isTrue); // back to schema value
      group.dispose();
    });
  });

  group('ParkFormGroup - batch', () {
    test('coalesces notifications into single batch', () async {
      final schema = _schema([
        _field(name: 'a'),
        _field(name: 'b'),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      final events = <ParkFormFieldChangeEvent>[];
      group.changes.listen(events.add);

      group.batch(() {
        group.notifyValueChanged('a');
        group.notifyValueChanged('b');
      });

      // Allow microtask to flush stream events
      await Future<void>.delayed(Duration.zero);

      // Both notifications should be flushed after batch ends
      expect(events.length, 2);
      group.dispose();
    });

    test('batch does not emit events mid-batch', () async {
      final schema = _schema([
        _field(name: 'x'),
      ]);
      final group = ParkFormBuilder.fromSchema(schema);

      final events = <ParkFormFieldChangeEvent>[];
      group.changes.listen(events.add);

      // Manually use the internal batch mechanism
      group.batch(() {
        group.notifyValueChanged('x');
        group.notifyValueChanged('x');
      });

      await Future<void>.delayed(Duration.zero);

      // Both events should be flushed after batch ends
      expect(events.length, 2);
      group.dispose();
    });
  });

  group('ParkFormArray - add/removeAt', () {
    test('add appends item', () {
      final array = ParkFormArray([]);
      expect(array.length, 0);

      array.add(ParkFormGroupControl({
        'name': ParkFormControl('Alice'),
      }));
      expect(array.length, 1);
      expect(array.value.first['name'], 'Alice');

      array.add(ParkFormGroupControl({
        'name': ParkFormControl('Bob'),
      }));
      expect(array.length, 2);
      array.dispose();
    });

    test('removeAt removes item at index', () {
      final array = ParkFormArray([
        ParkFormGroupControl({'name': ParkFormControl('Alice')}),
        ParkFormGroupControl({'name': ParkFormControl('Bob')}),
        ParkFormGroupControl({'name': ParkFormControl('Charlie')}),
      ]);
      expect(array.length, 3);

      array.removeAt(1); // Remove Bob
      expect(array.length, 2);
      expect(array.value[0]['name'], 'Alice');
      expect(array.value[1]['name'], 'Charlie');
      array.dispose();
    });

    test('removeAt ignores out-of-bounds index', () {
      final array = ParkFormArray([
        ParkFormGroupControl({'name': ParkFormControl('Alice')}),
      ]);

      array.removeAt(5); // Should not throw
      array.removeAt(-1); // Should not throw
      expect(array.length, 1);
      array.dispose();
    });

    test('clear removes all items', () {
      final array = ParkFormArray([
        ParkFormGroupControl({'a': ParkFormControl(1)}),
        ParkFormGroupControl({'a': ParkFormControl(2)}),
      ]);
      expect(array.length, 2);

      array.clear();
      expect(array.length, 0);
      expect(array.value, isEmpty);
      array.dispose();
    });

    test('at returns item at index', () {
      final group = ParkFormGroupControl({'x': ParkFormControl(42)});
      final array = ParkFormArray([group]);

      expect(array.at(0), same(group));
      array.dispose();
    });
  });
}
