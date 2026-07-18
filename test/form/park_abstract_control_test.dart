/// Tests for ParkAbstractControl / ParkFormControl.
///
/// Covers: creation, setValue, setErrors, reset, dirty/pristine,
/// touched/untouched, valueChanges, statusChanges, enable/disable,
/// async validators.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/form/group/form_group_exports.dart';

void main() {
  group('ParkFormControl - creation', () {
    test('creates with initial value', () {
      final control = ParkFormControl('hello');
      expect(control.value, 'hello');
      expect(control.valid, isTrue);
      expect(control.pristine, isTrue);
      expect(control.untouched, isTrue);
      expect(control.enabled, isTrue);
      control.dispose();
    });

    test('creates with null value', () {
      final control = ParkFormControl(null);
      expect(control.value, isNull);
      control.dispose();
    });

    test('creates with numeric value', () {
      final control = ParkFormControl(42);
      expect(control.value, 42);
      control.dispose();
    });
  });

  group('ParkFormControl - setValue', () {
    test('updates value and marks dirty + touched', () {
      final control = ParkFormControl('initial');
      control.setValue('updated');

      expect(control.value, 'updated');
      expect(control.dirty, isTrue);
      expect(control.touched, isTrue);
      control.dispose();
    });

    test('setValue with markDirty=false keeps pristine', () {
      final control = ParkFormControl('initial');
      control.setValue('updated', markDirty: false);

      expect(control.value, 'updated');
      expect(control.pristine, isTrue);
      expect(control.untouched, isTrue);
      control.dispose();
    });

    test('setValue with emitEvent=false does not emit on valueChanges', () async {
      final control = ParkFormControl('initial');
      final values = <dynamic>[];
      control.valueChanges.listen(values.add);

      control.setValue('silent', emitEvent: false);
      await Future<void>.delayed(Duration.zero);

      expect(values, isEmpty);
      control.dispose();
    });
  });

  group('ParkFormControl - validation', () {
    test('sync validator marks control invalid', () {
      final control = ParkFormControl(
        '',
        validators: [
          (dynamic v) {
            if (v == null || (v is String && v.isEmpty)) {
              return ParkFormError('required', 'Required');
            }
            return null;
          },
        ],
      );

      control.setValue('');
      expect(control.invalid, isTrue);
      expect(control.errors.length, 1);
      expect(control.errors.first.key, 'required');
      control.dispose();
    });

    test('sync validator passes with valid value', () {
      final control = ParkFormControl(
        'hello',
        validators: [
          (dynamic v) {
            if (v == null || (v is String && v.isEmpty)) {
              return ParkFormError('required', 'Required');
            }
            return null;
          },
        ],
      );

      control.setValue('hello');
      expect(control.valid, isTrue);
      expect(control.errors, isEmpty);
      control.dispose();
    });

    test('async validator executes', () async {
      final control = ParkFormControl(
        'test',
        asyncValidators: [
          (dynamic v) async {
            await Future<void>.delayed(const Duration(milliseconds: 10));
            if (v == 'taken') {
              return ParkFormError('unique', 'Already taken');
            }
            return null;
          },
        ],
      );

      control.setValue('test');
      final result = await control.validate();
      expect(result, isTrue);
      expect(control.valid, isTrue);

      control.setValue('taken');
      final result2 = await control.validate();
      expect(result2, isFalse);
      expect(control.errors.first.key, 'unique');
      control.dispose();
    });

    test('setValidators replaces sync validators', () {
      final control = ParkFormControl(
        '',
        validators: [
          (dynamic v) => ParkFormError('old', 'Old error'),
        ],
      );

      control.setValue('');
      expect(control.errors.first.key, 'old');

      control.setValidators([
        (dynamic v) => ParkFormError('new', 'New error'),
      ]);
      expect(control.errors.first.key, 'new');
      control.dispose();
    });
  });

  group('ParkFormControl - reset', () {
    test('reset restores to null', () {
      final control = ParkFormControl('initial');
      control.setValue('changed');
      expect(control.value, 'changed');
      expect(control.dirty, isTrue);

      control.reset();
      expect(control.value, isNull);
      expect(control.pristine, isTrue);
      expect(control.untouched, isTrue);
      expect(control.errors, isEmpty);
      control.dispose();
    });

    test('reset with defaultValue restores to default', () {
      final control = ParkFormControl('initial', defaultValue: 'default');
      control.setValue('changed');

      control.reset();
      expect(control.value, 'default');
      expect(control.pristine, isTrue);
      control.dispose();
    });

    test('reset with explicit value overrides defaultValue', () {
      final control = ParkFormControl('initial', defaultValue: 'default');
      control.setValue('changed');

      control.reset('explicit');
      expect(control.value, 'explicit');
      control.dispose();
    });

    test('reset clears validation errors', () {
      final control = ParkFormControl(
        '',
        validators: [
          (dynamic v) {
            if (v == null || (v is String && v.isEmpty)) {
              return ParkFormError('required', 'Required');
            }
            return null;
          },
        ],
      );

      control.setValue('');
      expect(control.invalid, isTrue);

      control.reset();
      expect(control.valid, isTrue);
      expect(control.errors, isEmpty);
      control.dispose();
    });
  });

  group('ParkFormControl - dirty/pristine and touched/untouched', () {
    test('markAsTouched / markAsUntouched', () {
      final control = ParkFormControl('val');
      expect(control.untouched, isTrue);

      control.markAsTouched();
      expect(control.touched, isTrue);

      control.markAsUntouched();
      expect(control.untouched, isTrue);
      control.dispose();
    });

    test('markAsDirty / markAsPristine', () {
      final control = ParkFormControl('val');
      expect(control.pristine, isTrue);

      control.markAsDirty();
      expect(control.dirty, isTrue);

      control.markAsPristine();
      expect(control.pristine, isTrue);
      control.dispose();
    });
  });

  group('ParkFormControl - valueChanges stream', () {
    test('emits on setValue', () async {
      final control = ParkFormControl('initial');
      final values = <dynamic>[];
      control.valueChanges.listen(values.add);

      control.setValue('a');
      control.setValue('b');
      await Future<void>.delayed(Duration.zero);

      expect(values, ['a', 'b']);
      control.dispose();
    });

    test('emits on reset', () async {
      final control = ParkFormControl('initial');
      final values = <dynamic>[];
      control.valueChanges.listen(values.add);

      control.reset('resetVal');
      await Future<void>.delayed(Duration.zero);

      expect(values, ['resetVal']);
      control.dispose();
    });
  });

  group('ParkFormControl - statusChanges stream', () {
    test('emits VALID then INVALID on validation failure', () async {
      final control = ParkFormControl(
        'valid',
        validators: [
          (dynamic v) {
            if (v == null || (v is String && v.isEmpty)) {
              return ParkFormError('required', 'Required');
            }
            return null;
          },
        ],
      );

      final statuses = <String>[];
      control.statusChanges.listen(statuses.add);

      control.setValue('valid');
      control.setValue('');
      await Future<void>.delayed(Duration.zero);

      expect(statuses, containsAllInOrder(['VALID', 'INVALID']));
      control.dispose();
    });

    test('emits PENDING during async validation', () async {
      final control = ParkFormControl(
        'test',
        asyncValidators: [
          (dynamic v) async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            return null;
          },
        ],
      );

      final statuses = <String>[];
      control.statusChanges.listen(statuses.add);

      // Start async validation
      final future = control.validate();

      // Allow microtask to flush
      await Future<void>.delayed(Duration.zero);
      expect(statuses, contains('PENDING'));

      await future;
      await Future<void>.delayed(Duration.zero);
      expect(statuses.last, 'VALID');
      control.dispose();
    });
  });

  group('ParkFormControl - enable/disable', () {
    test('disable sets disabled=true', () {
      final control = ParkFormControl('val');
      expect(control.enabled, isTrue);

      control.disable();
      expect(control.disabled, isTrue);
      expect(control.enabled, isFalse);
      control.dispose();
    });

    test('enable re-enables after disable', () {
      final control = ParkFormControl('val');
      control.disable();
      expect(control.disabled, isTrue);

      control.enable();
      expect(control.enabled, isTrue);
      control.dispose();
    });

    test('disable emits status change', () async {
      final control = ParkFormControl('val');
      final statuses = <String>[];
      control.statusChanges.listen(statuses.add);

      control.disable();
      await Future<void>.delayed(Duration.zero);

      expect(statuses, isNotEmpty);
      control.dispose();
    });
  });

  group('ParkFormControl - status property', () {
    test('status is VALID when no errors', () {
      final control = ParkFormControl('val');
      expect(control.status, 'VALID');
      control.dispose();
    });

    test('status is INVALID when errors exist', () {
      final control = ParkFormControl(
        '',
        validators: [
          (dynamic v) => ParkFormError('required', 'Required'),
        ],
      );
      control.setValue('');
      expect(control.status, 'INVALID');
      control.dispose();
    });

    test('status is PENDING during async validation', () async {
      final control = ParkFormControl(
        'test',
        asyncValidators: [
          (dynamic v) async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return null;
          },
        ],
      );

      final future = control.validate();
      expect(control.status, 'PENDING');

      await future;
      expect(control.status, 'VALID');
      control.dispose();
    });
  });
}
