/// Tests for ParkFormArray.
///
/// Covers: creation, add, removeAt, addAt, clear, at(), length,
/// reset() removing dynamic items, valueChanges, validation.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/form/group/form_group_exports.dart';

void main() {
  group('ParkFormArray - creation', () {
    test('creates with empty list', () {
      final array = ParkFormArray([]);
      expect(array.length, 0);
      expect(array.value, isEmpty);
      expect(array.valid, isTrue);
      array.dispose();
    });

    test('creates with initial items', () {
      final array = ParkFormArray([
        ParkFormGroupControl({'name': ParkFormControl('Alice')}),
        ParkFormGroupControl({'name': ParkFormControl('Bob')}),
      ]);
      expect(array.length, 2);
      expect(array.value[0]['name'], 'Alice');
      expect(array.value[1]['name'], 'Bob');
      array.dispose();
    });
  });

  group('ParkFormArray - add', () {
    test('add appends item to end', () {
      final array = ParkFormArray([]);
      array.add(ParkFormGroupControl({'name': ParkFormControl('Alice')}));
      expect(array.length, 1);
      expect(array.value.first['name'], 'Alice');

      array.add(ParkFormGroupControl({'name': ParkFormControl('Bob')}));
      expect(array.length, 2);
      expect(array.value.last['name'], 'Bob');
      array.dispose();
    });

    test('add emits valueChanges', () async {
      final array = ParkFormArray([]);
      final values = <List<Map<String, dynamic>>>[];
      array.valueChanges.listen((dynamic v) {
        values.add(v as List<Map<String, dynamic>>);
      });

      array.add(ParkFormGroupControl({'name': ParkFormControl('Alice')}));
      await Future<void>.delayed(Duration.zero);

      expect(values.length, 1);
      expect(values.first.first['name'], 'Alice');
      array.dispose();
    });
  });

  group('ParkFormArray - addAt (insert)', () {
    test('addAt inserts at specified index', () {
      final array = ParkFormArray([
        ParkFormGroupControl({'name': ParkFormControl('Alice')}),
        ParkFormGroupControl({'name': ParkFormControl('Charlie')}),
      ]);

      array.addAt(
        1,
        ParkFormGroupControl({'name': ParkFormControl('Bob')}),
      );
      expect(array.length, 3);
      expect(array.value[0]['name'], 'Alice');
      expect(array.value[1]['name'], 'Bob');
      expect(array.value[2]['name'], 'Charlie');
      array.dispose();
    });

    test('addAt at index 0 inserts at beginning', () {
      final array = ParkFormArray([
        ParkFormGroupControl({'name': ParkFormControl('Bob')}),
      ]);

      array.addAt(
        0,
        ParkFormGroupControl({'name': ParkFormControl('Alice')}),
      );
      expect(array.value.first['name'], 'Alice');
      array.dispose();
    });
  });

  group('ParkFormArray - removeAt', () {
    test('removes item at index', () {
      final array = ParkFormArray([
        ParkFormGroupControl({'name': ParkFormControl('Alice')}),
        ParkFormGroupControl({'name': ParkFormControl('Bob')}),
        ParkFormGroupControl({'name': ParkFormControl('Charlie')}),
      ]);

      array.removeAt(1); // Remove Bob
      expect(array.length, 2);
      expect(array.value[0]['name'], 'Alice');
      expect(array.value[1]['name'], 'Charlie');
      array.dispose();
    });

    test('ignores out-of-bounds index', () {
      final array = ParkFormArray([
        ParkFormGroupControl({'name': ParkFormControl('Alice')}),
      ]);

      array.removeAt(5); // Should not throw
      array.removeAt(-1); // Should not throw
      expect(array.length, 1);
      array.dispose();
    });

    test('removeAt emits valueChanges', () async {
      final array = ParkFormArray([
        ParkFormGroupControl({'name': ParkFormControl('Alice')}),
        ParkFormGroupControl({'name': ParkFormControl('Bob')}),
      ]);

      final values = <dynamic>[];
      array.valueChanges.listen(values.add);

      array.removeAt(0);
      await Future<void>.delayed(Duration.zero);

      expect(values.length, 1);
      expect(array.length, 1);
      array.dispose();
    });
  });

  group('ParkFormArray - at()', () {
    test('returns item at index', () {
      final group0 = ParkFormGroupControl({'x': ParkFormControl(0)});
      final group1 = ParkFormGroupControl({'x': ParkFormControl(1)});
      final array = ParkFormArray([group0, group1]);

      expect(array.at(0), same(group0));
      expect(array.at(1), same(group1));
      array.dispose();
    });

    test('throws RangeError for invalid index', () {
      final array = ParkFormArray([
        ParkFormGroupControl({'x': ParkFormControl(0)}),
      ]);

      expect(() => array.at(5), throwsA(isA<RangeError>()));
      array.dispose();
    });
  });

  group('ParkFormArray - length/size', () {
    test('length reflects add/remove operations', () {
      final array = ParkFormArray([]);
      expect(array.length, 0);

      array.add(ParkFormGroupControl({'a': ParkFormControl(1)}));
      expect(array.length, 1);

      array.add(ParkFormGroupControl({'a': ParkFormControl(2)}));
      expect(array.length, 2);

      array.removeAt(0);
      expect(array.length, 1);
      array.dispose();
    });
  });

  group('ParkFormArray - clear', () {
    test('clear removes all items', () {
      final array = ParkFormArray([
        ParkFormGroupControl({'a': ParkFormControl(1)}),
        ParkFormGroupControl({'a': ParkFormControl(2)}),
        ParkFormGroupControl({'a': ParkFormControl(3)}),
      ]);
      expect(array.length, 3);

      array.clear();
      expect(array.length, 0);
      expect(array.value, isEmpty);
      array.dispose();
    });

    test('clear on empty array does not throw', () {
      final array = ParkFormArray([]);
      array.clear();
      expect(array.length, 0);
      array.dispose();
    });
  });

  group('ParkFormArray - reset', () {
    test('reset clears dynamically added items beyond initial count', () {
      final array = ParkFormArray([
        ParkFormGroupControl({'name': ParkFormControl('Alice', defaultValue: 'Alice')}),
      ]);
      expect(array.length, 1);

      // Dynamically add items
      array.add(ParkFormGroupControl({'name': ParkFormControl('Bob')}));
      array.add(ParkFormGroupControl({'name': ParkFormControl('Charlie')}));
      expect(array.length, 3);

      // Reset should remove dynamically added items
      array.reset();
      expect(array.length, 1);
      expect(array.value.first['name'], 'Alice');
      array.dispose();
    });

    test('reset restores initial items to pristine state', () {
      final array = ParkFormArray([
        ParkFormGroupControl({'name': ParkFormControl('Alice', defaultValue: 'Alice')}),
      ]);

      // Modify the initial item
      array.at(0).patchValue({'name': 'Modified'});
      expect(array.value.first['name'], 'Modified');

      array.reset();
      expect(array.value.first['name'], 'Alice');
      array.dispose();
    });

    test('reset on empty array does not throw', () {
      final array = ParkFormArray([]);
      array.reset();
      expect(array.length, 0);
      array.dispose();
    });

    test('reset emits valueChanges', () async {
      final array = ParkFormArray([
        ParkFormGroupControl({'name': ParkFormControl('Alice')}),
      ]);
      array.add(ParkFormGroupControl({'name': ParkFormControl('Bob')}));

      final values = <dynamic>[];
      array.valueChanges.listen(values.add);

      array.reset();
      await Future<void>.delayed(Duration.zero);

      expect(values, isNotEmpty);
      array.dispose();
    });
  });

  group('ParkFormArray - value', () {
    test('value returns list of group values', () {
      final array = ParkFormArray([
        ParkFormGroupControl({
          'name': ParkFormControl('Alice'),
          'age': ParkFormControl(30),
        }),
        ParkFormGroupControl({
          'name': ParkFormControl('Bob'),
          'age': ParkFormControl(25),
        }),
      ]);

      final value = array.value;
      expect(value.length, 2);
      expect(value[0]['name'], 'Alice');
      expect(value[0]['age'], 30);
      expect(value[1]['name'], 'Bob');
      expect(value[1]['age'], 25);
      array.dispose();
    });

    test('value updates when child controls change', () {
      final group = ParkFormGroupControl({'name': ParkFormControl('Alice')});
      final array = ParkFormArray([group]);

      expect(array.value.first['name'], 'Alice');

      group.patchValue({'name': 'Updated'});
      expect(array.value.first['name'], 'Updated');
      array.dispose();
    });
  });

  group('ParkFormArray - validation', () {
    test('valid when all items are valid', () async {
      final array = ParkFormArray([
        ParkFormGroupControl({
          'name': ParkFormControl('Alice', validators: [
            (dynamic v) {
              if (v == null || (v is String && v.isEmpty)) {
                return ParkFormError('required', 'Required');
              }
              return null;
            },
          ]),
        }),
      ]);

      final result = await array.validate();
      expect(result, isTrue);
      expect(array.valid, isTrue);
      array.dispose();
    });

    test('invalid when any item is invalid', () async {
      final array = ParkFormArray([
        ParkFormGroupControl({
          'name': ParkFormControl('Alice', validators: [
            (dynamic v) {
              if (v == null || (v is String && v.isEmpty)) {
                return ParkFormError('required', 'Required');
              }
              return null;
            },
          ]),
        }),
        ParkFormGroupControl({
          'name': ParkFormControl('', validators: [
            (dynamic v) {
              if (v == null || (v is String && v.isEmpty)) {
                return ParkFormError('required', 'Required');
              }
              return null;
            },
          ]),
        }),
      ]);

      final result = await array.validate();
      expect(result, isFalse);
      expect(array.valid, isFalse);
      array.dispose();
    });
  });

  group('ParkFormArray - items property', () {
    test('items returns unmodifiable list', () {
      final array = ParkFormArray([
        ParkFormGroupControl({'a': ParkFormControl(1)}),
      ]);

      final items = array.items;
      expect(items.length, 1);
      expect(() => items.add(ParkFormGroupControl({})), throwsA(isA<UnsupportedError>()));
      array.dispose();
    });
  });
}
